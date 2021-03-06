package modelhelper

import (
	"errors"
	"koding/db/models"

	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

// GroupDataColl holds the collection name for JGroupData model.
const GroupDataColl = "jGroupDatas"

var errPathNotSet = errors.New("path is not set")

// GetGroupData fetches the group data from db.
func GetGroupData(slug string) (*models.GroupData, error) {
	gd := new(models.GroupData)

	query := func(c *mgo.Collection) error {
		return c.Find(bson.M{"slug": slug}).One(&gd)
	}

	return gd, Mongo.Run(GroupDataColl, query)
}

// GetGroupDataPath fetches the group data from db but only the given path.
func GetGroupDataPath(slug, path string) (*models.GroupData, error) {
	if path == "" {
		return nil, errPathNotSet
	}

	gd := new(models.GroupData)
	query := func(c *mgo.Collection) error {
		return c.Find(bson.M{"slug": slug}).Select(bson.M{"data." + path: 1}).One(&gd)
	}

	return gd, Mongo.Run(GroupDataColl, query)
}

// HasGroupDataPath checks if the given path has data or not.
func HasGroupDataPath(slug, path string) (bool, error) {
	gdp, err := GetGroupDataPath(slug, path)
	if err != nil {
		return false, err
	}

	data, err := gdp.Data.Get(path)
	if err != nil {
		return false, err
	}

	return data != nil, nil
}

// UpsertGroupData creates or updates GroupData.
func UpsertGroupData(slug, path string, data interface{}) error {
	if path == "" {
		return errPathNotSet
	}

	// Insert with internally created id.
	op := func(c *mgo.Collection) error {
		_, err := c.Upsert(
			bson.M{"slug": slug},
			bson.M{
				"$set": bson.M{
					"data." + path: data,
				},
			},
		)
		return err
	}

	return Mongo.Run(GroupDataColl, op)
}
